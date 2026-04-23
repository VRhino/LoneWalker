export interface JwtPayload {
  sub: string;
  type?: string;
  iat?: number;
  exp?: number;
}
