# Simulated tutoring program evaluation

A small, **simulated** (not real) dataset for demonstrating baseline
equivalence assessment in a quasi-experimental education evaluation. It
represents 400 students: 200 who received a tutoring program and 200
comparison students who did not, with baseline covariates measured
before the program and an outcome measured after. The treatment group is
mildly positively selected, so the covariates span all three What Works
Clearinghouse equivalence categories.

## Usage

``` r
tutoring
```

## Format

A data frame with 400 rows and 8 variables:

- treat:

  Treatment indicator: 1 = received tutoring, 0 = comparison.

- pretest:

  Baseline reading score (continuous).

- attendance:

  Baseline attendance rate, 0-1 (continuous).

- age:

  Age in years at baseline (continuous).

- female:

  1 = female, 0 = not (binary).

- frpl:

  Eligible for free or reduced-price lunch: 1 = yes (binary).

- ell:

  English language learner: 1 = yes (binary).

- posttest:

  Reading score after the program (continuous outcome).

## Source

Simulated for package examples with `data-raw/tutoring.R`; not real
student data.
