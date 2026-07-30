import { Controller } from "@hotwired/stimulus"

// Mirrors Workout#lifting_score / successful_set_load for immediate display while logging a
// calculated lifting score. LogScoring still recalculates on submit; this controller is only a
// preview, so keep it in sync with the server algorithm when scoring rules change.
export default class extends Controller {
  static targets = ["score", "set", "reps", "load"]

  connect() {
    this.update()
  }

  update() {
    if (!this.hasScoreTarget) return

    const heaviestLoad = this.setTargets.reduce((heaviest, set) => {
      const prescribedReps = this.numberValue(set.dataset.liftingScorePrescribedReps)
      const reps = this.numberValue(this.repsTargetFor(set)?.value)
      const load = this.numberValue(this.loadTargetFor(set)?.value)

      // This is not a validation layer or the submitted source of truth; it only includes sets
      // that already look complete and successful enough to preview a score.
      if (prescribedReps === null || reps === null || load === null || reps < prescribedReps) {
        return heaviest
      }

      return heaviest === null ? load : Math.max(heaviest, load)
    }, null)

    this.scoreTarget.value = heaviestLoad === null ? "" : heaviestLoad
  }

  repsTargetFor(set) {
    return this.repsTargets.find((target) => set.contains(target))
  }

  loadTargetFor(set) {
    return this.loadTargets.find((target) => set.contains(target))
  }

  numberValue(value) {
    if (value === undefined || value === null || value === "") return null

    const number = Number(value)
    return Number.isNaN(number) ? null : number
  }
}
