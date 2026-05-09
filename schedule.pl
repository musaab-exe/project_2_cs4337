% Project 2 - Work Schedule Planner
% CS4337 Spring 2026
% Commit 2 - fixed idle workstations and some constraints

% plan/1 - main predicate
plan(plan(Morning, Evening, Night)) :-
    findall(E, employee(E), Employees),
    findall(ws(W, Min, Max), workstation(W, Min, Max), Workstations),
    assign_shift(morning, Employees, Workstations, Morning, Rest1),
    assign_shift(evening, Rest1, Workstations, Evening, Rest2),
    assign_shift(night, Rest2, Workstations, Night, Rest3),
    Rest3 = [].

% assign_shift/5 - assigns employees to workstations for a given shift
% now filters idle workstations
assign_shift(Shift, Employees, Workstations, Schedule, Remaining) :-
    filter_idle(Shift, Workstations, ActiveWS),
    % filter out employees who cant work this shift
    filter_shift_avoids(Shift, Employees, AvailableEmps),
    build_schedule(Shift, AvailableEmps, ActiveWS, Schedule, Remaining).

% filter out workstations that are idle this shift
filter_idle(_, [], []).
filter_idle(Shift, [ws(W, Min, Max)|Rest], Filtered) :-
    workstation_idle(W, Shift), !,
    filter_idle(Shift, Rest, Filtered).
filter_idle(Shift, [WS|Rest], [WS|Filtered]) :-
    filter_idle(Shift, Rest, Filtered).

% filter employees who avoid this shift
filter_shift_avoids(_, [], []).
filter_shift_avoids(Shift, [E|Rest], Filtered) :-
    avoid_shift(E, Shift), !,
    filter_shift_avoids(Shift, Rest, Filtered).
filter_shift_avoids(Shift, [E|Rest], [E|Filtered]) :-
    filter_shift_avoids(Shift, Rest, Filtered).

% build_schedule/5 - builds the schedule for one shift
build_schedule(_, Employees, [], [], Employees).
build_schedule(Shift, Employees, [ws(W, Min, Max)|RestWS], [workstation(W, Assigned)|RestSchedule], Remaining) :-
    pick_employees(Employees, Min, Max, Assigned, LeftOver),
    % BUG: checking avoid_workstation AFTER picking, should check during
    check_avoids(Assigned, W),
    build_schedule(Shift, LeftOver, RestWS, RestSchedule, Remaining).

% pick_employees/5 - picks between Min and Max employees from the list
% BUG: this still only picks exactly Min, doesnt explore Min..Max range
pick_employees(Employees, Min, _Max, Picked, Rest) :-
    length(Picked, Min),
    append(Picked, Rest, Employees).

% check that no assigned employee avoids this workstation
% BUG: this fails the whole thing instead of trying different assignments
check_avoids([], _).
check_avoids([E|Rest], W) :-
    \+ avoid_workstation(E, W),
    check_avoids(Rest, W).

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