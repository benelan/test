const {
  repo: { repo, owner },
  payload: { issue, pull_request },
} = context;

const milestone_number = issue.milestone.id || pull_request.milestone.id;

const { data: milestone } = await github.issues.getMilestone({
  owner,
  repo,
  milestone_number,
});

const currentDate = new Date(Date.now());
currentDate.setUTCHours(0, 0, 0, 0);

// close milestone if it is past due and there are no open issues/PRs
!milestone.open_issues &&
  Date(milestone.due_on) > currentDate &&
  (await github.issues.updateMilestone({
    owner,
    repo,
    milestone_number,
    state: "closed",
  }));
