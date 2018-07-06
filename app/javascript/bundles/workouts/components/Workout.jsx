import React from 'react';

export default class Workout extends React.Component {
  render() {
    return(
      <a className="list-group-item list-group-item-action" href={"/workouts/" + this.props.workout.id}>{this.props.workout.name}</a>
    )}
}
