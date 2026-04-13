# Parallel RSpec Setup Implementation Plan

This document outlines the steps required to re-enable parallel testing using Knapsack Pro in the `full-stack.yml` CI workflow. 

## 1. Obtain a Knapsack Pro Token
* Sign up or log into [Knapsack Pro](https://knapsackpro.com/).
* Create a new project for this repository.
* Obtain the API token for the RSpec test suite.

## 2. Configure GitHub Secrets
* Go to the repository settings on GitHub (`Settings > Secrets and variables > Actions`).
* Add a new repository secret named `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` with the token obtained in step 1.

## 3. Update the CI Workflow (`.github/workflows/full-stack.yml`)
* Re-introduce the matrix strategy for `ci_node_total` and `ci_node_index` in the `build_and_test` job:
  ```yaml
  strategy:
    fail-fast: false
    matrix:
      ruby-version: [3.4.4]
      node-version: [22.x]
      ci_node_total: [2] # Set to desired number of parallel nodes
      ci_node_index: [0, 1] # Must match the total nodes (0 to total-1)
  ```
* Define `RUN_MODE` as `parallel` in the job's `env` block.
* Replace the single-node RSpec execution step with the Knapsack Pro parallel step:
  ```yaml
  - name: RSpec tests - parallel
    env:
      KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC: ${{ secrets.KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC }}
      KNAPSACK_PRO_CI_NODE_BUILD_ID: ${{ github.run_id }}
      KNAPSACK_PRO_CI_NODE_TOTAL: ${{ matrix.ci_node_total }}
      KNAPSACK_PRO_CI_NODE_INDEX: ${{ matrix.ci_node_index }}
      KNAPSACK_PRO_FIXED_QUEUE_SPLIT: true
      KNAPSACK_PRO_LOG_LEVEL: info
    run: |
      # Run all specs except those with the option skip_in_ci: true
      bundle exec rake "knapsack_pro:rspec[--tag ~skip_in_ci:true]"
  ```

## 4. Test the Pipeline
* Create a PR with these changes.
* Verify that the GitHub Actions run spins up multiple concurrent jobs (based on `ci_node_total`).
* Check the Knapsack Pro dashboard to ensure test timing data is being recorded successfully.
