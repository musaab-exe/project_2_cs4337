# Dev Log - CS4337 Project 2

---

## 2026-05-07 10:00 PM

First session. Read through the project spec. So basically I need to make a Prolog backend for a work scheduling webapp. The user defines employees, workstations with min/max capacities, and constraints. I need to implement plan/1 that generates valid schedules across three shifts (morning, evening, night).

The main things I need to do:
- plan/1 unifies with plan(Morning, Evening, Night) where each is a list of workstation/2 structures
- every employee works exactly one workstation for exactly one shift
- respect min/max employee counts per workstation
- filter out idle workstations per shift
- handle avoid_workstation and avoid_shift constraints
- if no valid plan exists, fail

My plan is to use findall to grab all employees and workstations into lists, then for each shift pick employees for each workstation. Prolog's backtracking should handle searching through combinations. Going to use the example input files to test.

Going to start coding tonight.

---

## 2026-05-08 5:30 PM

Coded up the basic structure. Got plan/1 generating a plan/3 structure with three shift schedules. Each shift goes through the workstations and uses append to split the employee list into groups.

The problem is my pick_employees only picks exactly Min employees using append. So workstation 2 in example 1 needs 5-9 people but I'm always assigning 5. Not enough slots for 26 employees so it fails on most inputs. Also I completely forgot about idle workstations - workstation 3 is idle in the morning but I'm still scheduling people there. And I'm not checking any of the avoid constraints at all. The works_at/4 and no_work/2 helpers seem fine at least.

Committing what I have.

---
## 2026-05-08 8:30 PM

New session. Goals for tonight:
- Filter out idle workstations before building schedule
- Add avoid_shift filtering so employees don't get scheduled for shifts they can't work
- Add avoid_workstation checking

Thoughts since last time: I think the idle filtering is easy, just skip workstations where workstation_idle matches. For avoid_shift I can filter the employee list before assigning a shift. avoid_workstation is trickier since I need to check it during assignment.

Added filter_idle/3 to remove idle workstations with a cut. Added filter_shift_avoids/3 to remove employees who can't work a shift. Same recursive pattern. For avoid_workstation I added check_avoids/2 that runs AFTER picking employees. This is dumb because if it picks ophelia for workstation 1 or 3 it just fails the whole assignment instead of trying different people. But whatever it partially works.

Still have the problem where pick_employees only picks Min employees. And the avoid_workstation check is in the wrong place. Committing anyway.

---