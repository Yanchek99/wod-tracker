import ReactOnRails from 'react-on-rails';

import WorkoutList from '../bundles/workouts/components/WorkoutList';
import Workout from '../bundles/workouts/components/Workout';

// This is how react_on_rails can see the HelloWorld in the browser.
ReactOnRails.register({
  Workout,
  WorkoutList,
});
