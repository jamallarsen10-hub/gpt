import React from 'react';
import { Composition } from 'remotion';
import { TransitionSeries, linearTiming } from '@remotion/transitions';
import { fade } from '@remotion/transitions/fade';
import { Scene1 } from './scenes/Scene1_WhatIsAgent';
import { Scene2 } from './scenes/Scene2_Components';
import { Scene3 } from './scenes/Scene3_Tools';
import { Scene4 } from './scenes/Scene4_Loop';
import { Scene5 } from './scenes/Scene5_Impact';

const SCENE_DURATION = 180;
const TRANSITION_DURATION = 12;

const MainVideo: React.FC = () => {
  return (
    <TransitionSeries>
      <TransitionSeries.Sequence durationInFrames={SCENE_DURATION}>
        <Scene1 />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: TRANSITION_DURATION })}
      />
      <TransitionSeries.Sequence durationInFrames={SCENE_DURATION}>
        <Scene2 />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: TRANSITION_DURATION })}
      />
      <TransitionSeries.Sequence durationInFrames={SCENE_DURATION}>
        <Scene3 />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: TRANSITION_DURATION })}
      />
      <TransitionSeries.Sequence durationInFrames={SCENE_DURATION}>
        <Scene4 />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: TRANSITION_DURATION })}
      />
      <TransitionSeries.Sequence durationInFrames={SCENE_DURATION}>
        <Scene5 />
      </TransitionSeries.Sequence>
    </TransitionSeries>
  );
};

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="HowAIAgentsWork"
      component={MainVideo}
      durationInFrames={900}
      fps={30}
      width={1080}
      height={1920}
    />
  );
};
