export const SRID_WGS84 = 4326;
export const EARTH_RADIUS_METERS = 6371000;
export const DEFAULT_SEARCH_RADIUS_M = 5000;
export const GPS_ACCURACY_THRESHOLD_M = 50;
export const WGS84_LAT_MIN = -90;
export const WGS84_LAT_MAX = 90;
export const WGS84_LNG_MIN = -180;
export const WGS84_LNG_MAX = 180;

export const FOG_OF_WAR_RADIUS_M = 15;
export const EXPLORATION_DEGRADATION_DAYS = 7;

export function buildGeoJsonPoint(lng: number, lat: number): string {
  return JSON.stringify({ type: 'Point', coordinates: [lng, lat] });
}
