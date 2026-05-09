# Project 2 - Work Schedule Planner
## Musaab J Mohammed

## Files
- schedule.pl - main Prolog code with plan/1 and helper predicates
- devlog.md - development log

## How to Run
Load the input file first, then the schedule file:
```
swipl
?- consult('example-input-1.pl').
?- consult('schedule.pl').
?- plan(Plan).
```
The input file needs to be loaded before schedule.pl since it defines the employee/workstation facts.

## Notes
- plan/1 generates multiple solutions through backtracking (press ; to see more)
- returns false if no valid schedule exists