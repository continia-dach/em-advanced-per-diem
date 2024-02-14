permissionset 62080 "Advanced Per Diem"
{
    Access = Internal;
    Assignable = true;
    Caption = 'All permissions', Locked = true;

    Permissions =
         codeunit "EMADV Cust. Per Diem Calc.Mgt." = X,
         codeunit "EMADV PD Rule Set AT" = X,
         codeunit "EMADV PD Rule Set DE" = X,
         codeunit "EMADV PD Rule Set Default" = X,
         page "EMADV Calculation Detail FB" = X,
         page "EMADV Meal Deduction List" = X,
         page "EMADV Per Diem Calc. Card" = X,
         page "EMADV Per Diem Calc. List" = X,
         page "EMADV Per Diem Det. Dest FB" = X,
         table "EMADV Meal Deduction" = X,
         table "EMADV Per Diem Calculation" = X,
         tabledata "EMADV Meal Deduction" = RIMD,
         tabledata "EMADV Per Diem Calculation" = RIMD;
}