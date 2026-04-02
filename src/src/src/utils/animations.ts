import { interpolate, spring } from 'remotion';

export function makeSpring(
  frame: number,
  fps: number,
  delay = 0,
  config?: { mass?: number; stiffness?: number }
): number {
  return spring({
    frame: frame - delay,
    fps,
    config: {
      damping: 200,
      mass: config?.mass ?? 1,
      stiffness: config?.stiffness ?? 100,
    },
  });
}

export function countUp(
  frame: number,
  startFrame: number,
  endFrame: number,
  from: number,
  to: number
): number {
  return interpolate(frame, [startFrame, endFrame], [from, to], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
}

export function fadeIn(frame: number, startFrame: number, fadeFrames = 12): number {
  return interpolate(frame, [startFrame, startFrame + fadeFrames], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
}

export function drawPath(
  frame: number,
  pathLength: number,
  startFrame: number,
  endFrame: number
): number {
  return interpolate(frame, [startFrame, endFrame], [pathLength, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
}