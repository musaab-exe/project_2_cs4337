% Project 2 - Work Schedule Planner

% plan/1 - main predicate
% unifies with plan(Morning, Evening, Night)
plan(plan(Morning, Evening, Night)) :-
    findall(E, employee(E), AllEmployees),
    findall(ws(W, Min, Max), workstation(W, Min, Max), AllWorkstations),
    get_active_ws(morning, AllWorkstations, MorningWS),
    get_active_ws(evening, AllWorkstations, EveningWS),
    get_active_ws(night, AllWorkstations, NightWS),
    % quick feasibility check: total minimums across all shifts <= total employees
    sum_mins(MorningWS, MMin),
    sum_mins(EveningWS, EMin),
    sum_mins(NightWS, NMin),
    length(AllEmployees, NumEmp),
    TotalMin is MMin + EMin + NMin,
    TotalMin =< NumEmp,
    % also check total maxes can hold everyone
    sum_maxes(MorningWS, MMax),
    sum_maxes(EveningWS, EMax),
    sum_maxes(NightWS, NMax),
    TotalMax is MMax + EMax + NMax,
    NumEmp =< TotalMax,
    % now actually assign
    available_for_shift(morning, AllEmployees, MorningAvail),
    available_for_shift(evening, AllEmployees, EveningAvail),
    available_for_shift(night, AllEmployees, NightAvail),
    assign_shift(morning, MorningAvail, MorningWS, Morning, UsedMorning),
    subtract_list(EveningAvail, UsedMorning, EveningLeft),
    assign_shift(evening, EveningLeft, EveningWS, Evening, UsedEvening),
    subtract_list(NightAvail, UsedMorning, NightLeft1),
    subtract_list(NightLeft1, UsedEvening, NightLeft),
    assign_shift(night, NightLeft, NightWS, Night, UsedNight),
    % make sure everyone got assigned
    append(UsedMorning, UsedEvening, Used12),
    append(Used12, UsedNight, AllUsed),
    length(AllUsed, NumEmp).

% sum minimum employees needed across workstations
sum_mins([], 0).
sum_mins([ws(_, Min, _)|Rest], Total) :-
    sum_mins(Rest, RestTotal),
    Total is Min + RestTotal.

% sum maximum employees across workstations
sum_maxes([], 0).
sum_maxes([ws(_, _, Max)|Rest], Total) :-
    sum_maxes(Rest, RestTotal),
    Total is Max + RestTotal.

% get workstations that are NOT idle for this shift
get_active_ws(_, [], []).
get_active_ws(Shift, [ws(W, _Min, _Max)|Rest], Active) :-
    workstation_idle(W, Shift), !,
    get_active_ws(Shift, Rest, Active).
get_active_ws(Shift, [WS|Rest], [WS|Active]) :-
    get_active_ws(Shift, Rest, Active).

% get employees available for a shift (not avoiding it)
available_for_shift(_, [], []).
available_for_shift(Shift, [E|Rest], Avail) :-
    avoid_shift(E, Shift), !,
    available_for_shift(Shift, Rest, Avail).
available_for_shift(Shift, [E|Rest], [E|Avail]) :-
    available_for_shift(Shift, Rest, Avail).

% assign_shift/5 - assign employees to active workstations for a shift
% returns the schedule and the flat list of all employees used
assign_shift(_, _, [], [], []).
assign_shift(Shift, Available, [ws(W, Min, Max)|RestWS], [workstation(W, Assigned)|RestSched], AllUsed) :-
    % check we have enough employees left for remaining workstations
    remaining_min(RestWS, RestMin),
    length(Available, NumAvail),
    NumAvail >= Min + RestMin,
    pick_n_between(Min, Max, Available, Shift, W, Assigned, Leftover),
    assign_shift(Shift, Leftover, RestWS, RestSched, RestUsed),
    append(Assigned, RestUsed, AllUsed).

% sum of minimums for remaining workstations (for pruning)
remaining_min([], 0).
remaining_min([ws(_, Min, _)|Rest], Total) :-
    remaining_min(Rest, RestTotal),
    Total is Min + RestTotal.

% pick_n_between/7 - pick N employees where Min =< N =< Max
% uses select for backtracking through different employee choices
pick_n_between(Min, Max, Available, Shift, W, Assigned, Leftover) :-
    between(Min, Max, N),
    pick_n(N, Available, Shift, W, Assigned, Leftover).

% pick exactly N employees who can work at workstation W
pick_n(0, Leftover, _, _, [], Leftover).
pick_n(N, Available, Shift, W, [E|RestPicked], Leftover) :-
    N > 0,
    select(E, Available, Remaining),
    \+ avoid_workstation(E, W),
    N1 is N - 1,
    pick_n(N1, Remaining, Shift, W, RestPicked, Leftover).

% subtract_list/3 - remove elements of second list from first list
subtract_list(List, [], List).
subtract_list(List, [H|T], Result) :-
    select(H, List, List2), !,
    subtract_list(List2, T, Result).
subtract_list(List, [_|T], Result) :-
    subtract_list(List, T, Result).

% ---- query helpers ----

% works_at/4 - check if employee works at a workstation in a shift
works_at(plan(Morning, _, _), morning, Employee, WS) :-
    member(workstation(WS, Emps), Morning),
    member(Employee, Emps).
works_at(plan(_, Evening, _), evening, Employee, WS) :-
    member(workstation(WS, Emps), Evening),
    member(Employee, Emps).
works_at(plan(_, _, Night), night, Employee, WS) :-
    member(workstation(WS, Emps), Night),
    member(Employee, Emps).

% no_work/2 - true if employee is not assigned anywhere
no_work(Plan, Employee) :-
    employee(Employee),
    \+ works_at(Plan, _, Employee, _).

% double_work/2 - true if employee is assigned more than once
double_work(Plan, Employee) :-
    employee(Employee),
    works_at(Plan, S1, Employee, W1),
    works_at(Plan, S2, Employee, W2),
    (S1 \= S2 ; W1 \= W2).