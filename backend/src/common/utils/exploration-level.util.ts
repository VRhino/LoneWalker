import {
  EXPLORATION_DEGRADATION_DAYS,
  EXPLORATION_DEGRADATION_WINDOW_DAYS,
  EXPLORATION_MAX_LEVEL,
  EXPLORATION_MIN_LEVEL,
  MILLISECONDS_PER_DAY,
} from '../constants/geo.constants';

/**
 * Computes the fog-clearing level (0–100) for an explored area based on its age.
 *
 * - 0 to EXPLORATION_DEGRADATION_DAYS: full visibility (MAX_LEVEL)
 * - After that window: linear fade to MIN_LEVEL over DEGRADATION_WINDOW_DAYS
 * - Beyond both windows: minimum visibility (MIN_LEVEL) — area never fully re-fogs
 */
export function computeExploredLevel(exploredAt: Date | string): number {
  const ageDays =
    (Date.now() - new Date(exploredAt).getTime()) / MILLISECONDS_PER_DAY;

  if (ageDays <= EXPLORATION_DEGRADATION_DAYS) {
    return EXPLORATION_MAX_LEVEL;
  }

  const endOfDegradation =
    EXPLORATION_DEGRADATION_DAYS + EXPLORATION_DEGRADATION_WINDOW_DAYS;

  if (ageDays >= endOfDegradation) {
    return EXPLORATION_MIN_LEVEL;
  }

  const degradationProgress =
    (ageDays - EXPLORATION_DEGRADATION_DAYS) /
    EXPLORATION_DEGRADATION_WINDOW_DAYS;
  const levelRange = EXPLORATION_MAX_LEVEL - EXPLORATION_MIN_LEVEL;

  return EXPLORATION_MAX_LEVEL - degradationProgress * levelRange;
}
