% Project 2 - Work Schedule Planner

% plan/1 - main predicate
% Takes an unbound variable and unifies it with a plan/3 structure
plan(plan(Morning, Evening, Night)) :-
    findall(E, employee(E), Employees),
    findall(ws(W, Min, Max), workstation(W, Min, Max), Workstations),
    assign_shift(morning, Employees, Workstations, Morning, Rest1),
    assign_shift(evening, Rest1, Workstations, Evening, Rest2),
    assign_shift(night, Rest2, Workstations, Night, Rest3),
    Rest3 = [].

% assign_shift/5 - assigns employees to workstations for a given shift
% BUG: not filtering out idle workstations
% BUG: not checking avoid_workstation or avoid_shift
assign_shift(Shift, Employees, Workstations, Schedule, Remaining) :-
    build_schedule(Shift, Employees, Workstations, Schedule, Remaining).

% build_schedule/5 - builds the schedule for one shift
build_schedule(_, Employees, [], [], Employees).
build_schedule(Shift, Employees, [ws(W, Min, Max)|RestWS], [workstation(W, Assigned)|RestSchedule], Remaining) :-
    pick_employees(Employees, Min, Max, Assigned, LeftOver),
    build_schedule(Shift, LeftOver, RestWS, RestSchedule, Remaining).

% pick_employees/5 - picks between Min and Max employees from the list
% BUG: always picks exactly Min employees, doesnt try different amounts
pick_employees(Employees, Min, _Max, Picked, Rest) :-
    length(Picked, Min),
    append(Picked, Rest, Employees).

% helper to check if employee works in plan
works_at(plan(Morning, Evening, Night), morning, Employee, WS) :-
    member(workstation(WS, Emps), Morning),
    member(Employee, Emps).
works_at(plan(Morning, Evening, Night), evening, Employee, WS) :-
    member(workstation(WS, Emps), Evening),
    member(Employee, Emps).
works_at(plan(Morning, Evening, Night), night, Employee, WS) :-
    member(workstation(WS, Emps), Night),
    member(Employee, Emps).

% no_work - true if employee has no assignment
no_work(Plan, Employee) :-
    employee(Employee),
    \+ works_at(Plan, _, Employee, _).

% double_work - true if employee works more than once
double_work(Plan, Employee) :-
    employee(Employee),
    works_at(Plan, S1, Employee, W1),
    works_at(Plan, S2, Employee, W2),
    (S1 \= S2 ; W1 \= W2).