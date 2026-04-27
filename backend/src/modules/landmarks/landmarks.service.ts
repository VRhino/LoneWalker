import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LandmarkEntity, LandmarkStatus } from './entities/landmark.entity';
import { LandmarkVoteEntity } from './entities/landmark-vote.entity';
import { CreateLandmarkDto } from './dto/create-landmark.dto';
import { VoteLandmarkDto } from './dto/vote-landmark.dto';
import { LandmarkDto, LandmarkCommentDto } from './dto/landmark-response.dto';
import { UsersService } from '../users/users.service';
import { MedalsService } from '../medals/medals.service';
import { GeoUtils } from '../../common/utils/geo.utils';
import { buildWktPoint } from '../../common/constants/geo.constants';

const VOTING_WINDOW_DAYS = 14;
const APPROVAL_THRESHOLD = 20;
const REVOKE_THRESHOLD = 10;
const PROPOSAL_PROXIMITY_M = 50;

const CARTOGRAPHER_POINTS = {
  PROPOSE: 10,
  APPROVED: 50,
  REJECTED: -5,
  VOTE: 1,
};

@Injectable()
export class LandmarksService {
  constructor(
    @InjectRepository(LandmarkEntity)
    private landmarkRepository: Repository<LandmarkEntity>,
    @InjectRepository(LandmarkVoteEntity)
    private voteRepository: Repository<LandmarkVoteEntity>,
    private usersService: UsersService,
    private medalsService: MedalsService,
  ) {}

  async proposeLandmark(
    userId: string,
    dto: CreateLandmarkDto,
  ): Promise<LandmarkDto> {
    const distance = GeoUtils.calculateDistance(
      dto.user_latitude,
      dto.user_longitude,
      dto.latitude,
      dto.longitude,
    );

    if (distance > PROPOSAL_PROXIMITY_M) {
      throw new BadRequestException(
        `You must be within ${PROPOSAL_PROXIMITY_M}m of the landmark to propose it. Current distance: ${distance.toFixed(1)}m`,
      );
    }

    const landmark = this.landmarkRepository.create({
      creator_id: userId,
      title: dto.title,
      description: dto.description,
      category: dto.category,
      latitude: dto.latitude,
      longitude: dto.longitude,
      photo_url: dto.photo_url ?? null,
      status: LandmarkStatus.VOTING,
      location: buildWktPoint(dto.longitude, dto.latitude),
    });

    const saved = await this.landmarkRepository.save(landmark);

    await this.usersService.addCartographerPoints(
      userId,
      CARTOGRAPHER_POINTS.PROPOSE,
    );

    return this.toDto(saved, userId, []);
  }

  async getLandmarksForVoting(userId?: string): Promise<LandmarkDto[]> {
    const landmarks = await this.landmarkRepository.find({
      where: { status: LandmarkStatus.VOTING },
      relations: ['creator'],
      order: { created_at: 'DESC' },
    });

    return Promise.all(
      landmarks.map(async l => {
        const userVote = userId
          ? await this.voteRepository.findOne({
              where: { landmark_id: l.id, user_id: userId },
            })
          : null;
        return this.toDto(l, userId, [], userVote?.vote ?? null);
      }),
    );
  }

  async getApprovedLandmarks(
    lat: number,
    lng: number,
    radiusMeters: number = 5000,
  ): Promise<LandmarkDto[]> {
    const landmarks = await this.landmarkRepository
      .createQueryBuilder('l')
      .innerJoinAndSelect('l.creator', 'u')
      .where('l.status = :status', { status: LandmarkStatus.APPROVED })
      .andWhere(
        'ST_DWithin(l.location::geography, ST_MakePoint(:lng, :lat)::geography, :radius)',
        { lng, lat, radius: radiusMeters },
      )
      .orderBy('ST_Distance(l.location, ST_MakePoint(:lng, :lat))', 'ASC')
      .setParameters({ lat, lng })
      .getMany();

    return landmarks.map(l => this.toDto(l, undefined, []));
  }

  async getLandmarkById(id: string, userId?: string): Promise<LandmarkDto> {
    const landmark = await this.landmarkRepository.findOne({
      where: { id },
      relations: ['creator'],
    });

    if (!landmark) {
      throw new NotFoundException('Landmark not found');
    }

    const votes = await this.voteRepository.find({
      where: { landmark_id: id },
      relations: ['user'],
      order: { created_at: 'DESC' },
    });

    const userVote = userId
      ? (votes.find(v => v.user_id === userId)?.vote ?? null)
      : null;

    return this.toDto(landmark, userId, votes, userVote);
  }

  async voteLandmark(
    userId: string,
    landmarkId: string,
    dto: VoteLandmarkDto,
  ): Promise<LandmarkDto> {
    const landmark = await this.landmarkRepository.findOne({
      where: { id: landmarkId },
      relations: ['creator'],
    });

    if (!landmark) {
      throw new NotFoundException('Landmark not found');
    }

    if (landmark.status !== LandmarkStatus.VOTING) {
      throw new BadRequestException('This landmark is not open for voting');
    }

    if (landmark.creator_id === userId) {
      throw new BadRequestException('You cannot vote on your own landmark');
    }

    const existing = await this.voteRepository.findOne({
      where: { landmark_id: landmarkId, user_id: userId },
    });

    if (existing) {
      throw new ConflictException('You have already voted on this landmark');
    }

    const vote = this.voteRepository.create({
      landmark_id: landmarkId,
      user_id: userId,
      vote: dto.vote,
      comment: dto.comment,
    });

    await this.voteRepository.save(vote);

    if (dto.vote === 1) {
      landmark.votes_positive += 1;
    } else {
      landmark.votes_negative += 1;
    }

    await this.landmarkRepository.save(landmark);
    await this.evaluateApproval(landmark);

    await this.usersService.addCartographerPoints(
      userId,
      CARTOGRAPHER_POINTS.VOTE,
    );
    await this.medalsService.checkAndAwardMedals(userId);

    return this.getLandmarkById(landmarkId, userId);
  }

  async getLandmarkComments(landmarkId: string): Promise<LandmarkCommentDto[]> {
    const votes = await this.voteRepository.find({
      where: { landmark_id: landmarkId },
      relations: ['user'],
      order: { created_at: 'DESC' },
    });

    return votes.map(v => ({
      id: v.id,
      user_id: v.user_id,
      username: v.user.username,
      vote: v.vote,
      comment: v.comment,
      created_at: v.created_at,
    }));
  }

  private async evaluateApproval(landmark: LandmarkEntity): Promise<void> {
    const netVotes = landmark.votes_positive - landmark.votes_negative;
    const daysSinceCreation = Math.floor(
      (Date.now() - landmark.created_at.getTime()) / (1000 * 60 * 60 * 24),
    );

    if (landmark.status === LandmarkStatus.VOTING) {
      if (netVotes >= APPROVAL_THRESHOLD) {
        landmark.status = LandmarkStatus.APPROVED;
        landmark.approved_at = new Date();
        await this.landmarkRepository.save(landmark);
        await this.usersService.addCartographerPoints(
          landmark.creator_id,
          CARTOGRAPHER_POINTS.APPROVED,
        );
        await this.medalsService.checkAndAwardMedals(landmark.creator_id);
        return;
      }

      if (
        daysSinceCreation >= VOTING_WINDOW_DAYS ||
        landmark.votes_negative > landmark.votes_positive
      ) {
        landmark.status = LandmarkStatus.REJECTED;
        await this.landmarkRepository.save(landmark);
        await this.usersService.addCartographerPoints(
          landmark.creator_id,
          CARTOGRAPHER_POINTS.REJECTED,
        );
      }
    } else if (landmark.status === LandmarkStatus.APPROVED) {
      if (
        landmark.votes_negative >
        landmark.votes_positive + REVOKE_THRESHOLD
      ) {
        landmark.status = LandmarkStatus.REJECTED;
        landmark.approved_at = null;
        await this.landmarkRepository.save(landmark);
      }
    }
  }

  private toDto(
    landmark: LandmarkEntity,
    _userId?: string,
    votes: LandmarkVoteEntity[] = [],
    userVote: number | null = null,
  ): LandmarkDto {
    const daysSince = Math.floor(
      (Date.now() - landmark.created_at.getTime()) / (1000 * 60 * 60 * 24),
    );
    const daysRemaining = Math.max(0, VOTING_WINDOW_DAYS - daysSince);

    return {
      id: landmark.id,
      creator_id: landmark.creator_id,
      creator_username: landmark.creator?.username ?? '',
      title: landmark.title,
      description: landmark.description,
      category: landmark.category,
      latitude: Number(landmark.latitude),
      longitude: Number(landmark.longitude),
      status: landmark.status,
      votes_positive: landmark.votes_positive,
      votes_negative: landmark.votes_negative,
      net_votes: landmark.votes_positive - landmark.votes_negative,
      photo_url: landmark.photo_url,
      days_remaining: daysRemaining,
      created_at: landmark.created_at,
      approved_at: landmark.approved_at,
      comments: votes.map(v => ({
        id: v.id,
        user_id: v.user_id,
        username: v.user?.username ?? '',
        vote: v.vote,
        comment: v.comment,
        created_at: v.created_at,
      })),
      user_vote: userVote,
    };
  }
}
