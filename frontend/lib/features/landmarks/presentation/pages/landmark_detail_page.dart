import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/landmark.dart';
import '../bloc/landmark_bloc.dart';
import '../bloc/landmark_event.dart';
import '../bloc/landmark_state.dart';

class LandmarkDetailPage extends StatefulWidget {
  final String landmarkId;

  const LandmarkDetailPage({super.key, required this.landmarkId});

  @override
  State<LandmarkDetailPage> createState() => _LandmarkDetailPageState();
}

class _LandmarkDetailPageState extends State<LandmarkDetailPage> {
  final _commentController = TextEditingController();
  int _selectedVote = 1;

  @override
  void initState() {
    super.initState();
    context
        .read<LandmarkBloc>()
        .add(LoadLandmarkDetailEvent(landmarkId: widget.landmarkId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitVote(Landmark landmark) {
    if (_commentController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El comentario debe tener al menos 10 caracteres'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    context.read<LandmarkBloc>().add(VoteLandmarkEvent(
          landmarkId: landmark.id,
          vote: _selectedVote,
          comment: _commentController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Landmark')),
      body: BlocConsumer<LandmarkBloc, LandmarkState>(
        listener: (context, state) {
          if (state is LandmarkVoted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Voto registrado!'),
                backgroundColor: Colors.green,
              ),
            );
            _commentController.clear();
          } else if (state is LandmarkError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LandmarkLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          Landmark? landmark;
          if (state is LandmarkDetailLoaded) landmark = state.landmark;
          if (state is LandmarkVoted) landmark = state.landmark;

          if (landmark == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final hasVoted = landmark.userVote != null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (landmark.photoUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      landmark.photoUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(height: 12),
                Chip(label: Text(landmark.category.label)),
                const SizedBox(height: 4),
                Text(landmark.title,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(landmark.description),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.thumb_up_outlined,
                        size: 20, color: Colors.green),
                    const SizedBox(width: 4),
                    Text('${landmark.votesPositive}',
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    const Icon(Icons.thumb_down_outlined,
                        size: 20, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('${landmark.votesNegative}',
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${landmark.daysRemaining}d restantes',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const Divider(height: 32),
                if (!hasVoted && landmark.status == LandmarkStatus.voting) ...[
                  Text('Tu voto',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.thumb_up_outlined, size: 16),
                              SizedBox(width: 4),
                              Text('Apoyo'),
                            ],
                          ),
                          selected: _selectedVote == 1,
                          onSelected: (_) => setState(() => _selectedVote = 1),
                          selectedColor: Colors.green.shade100,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.thumb_down_outlined, size: 16),
                              SizedBox(width: 4),
                              Text('Rechazo'),
                            ],
                          ),
                          selected: _selectedVote == -1,
                          onSelected: (_) => setState(() => _selectedVote = -1),
                          selectedColor: Colors.red.shade100,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Comentario (obligatorio, min. 10 caracteres)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is LandmarkLoading
                          ? null
                          : () => _submitVote(landmark!),
                      child: const Text('Enviar voto'),
                    ),
                  ),
                  const Divider(height: 32),
                ] else if (hasVoted) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          landmark.userVote == 1
                              ? 'Votaste a favor'
                              : 'Votaste en contra',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 32),
                ],
                Text('Comentarios (${landmark.comments.length})',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...landmark.comments.map((c) => _CommentTile(comment: c)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final LandmarkComment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  comment.vote == 1
                      ? Icons.thumb_up_outlined
                      : Icons.thumb_down_outlined,
                  size: 14,
                  color: comment.vote == 1 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(comment.username,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(comment.comment),
          ],
        ),
      ),
    );
  }
}
