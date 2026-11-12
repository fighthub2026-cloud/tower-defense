export const route = [
  [0, 345],
  [380, 345],
  [475, 345],
  [475, 165],
  [710, 165],
  [710, 450],
  [360, 450],
  [360, 670],
  [970, 670],
  [970, 820],
];
const lengths = route
  .slice(1)
  .map((p, i) => Math.hypot(p[0] - route[i][0], p[1] - route[i][1]));
export const total = lengths.reduce((a, b) => a + b, 0);
export function along(distance) {
  let d = Math.max(0, distance);
  for (let i = 0; i < lengths.length; i++) {
    if (d <= lengths[i]) {
      const t = d / lengths[i];
      return {
        x: route[i][0] + (route[i + 1][0] - route[i][0]) * t,
        y: route[i][1] + (route[i + 1][1] - route[i][1]) * t,
      };
    }
    d -= lengths[i];
  }
  return { x: 970, y: 850 };
}
export function distanceToPath(x, y) {
  let nearest = Infinity;
  for (let i = 0; i < lengths.length; i++) {
    const a = route[i],
      b = route[i + 1],
      t = Math.max(
        0,
        Math.min(
          1,
          ((x - a[0]) * (b[0] - a[0]) + (y - a[1]) * (b[1] - a[1])) /
            lengths[i] ** 2,
        ),
      );
    nearest = Math.min(
      nearest,
      Math.hypot(x - a[0] - t * (b[0] - a[0]), y - a[1] - t * (b[1] - a[1])),
    );
  }
  return nearest;
}
export function validSpot(x, y, units) {
  return (
    x > 40 &&
    x < 1200 &&
    y > 85 &&
    y < 760 &&
    distanceToPath(x, y) > 67 &&
    !units.some((u) => Math.hypot(u.x - x, u.y - y) < 70)
  );
}
