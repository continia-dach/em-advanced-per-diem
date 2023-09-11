codeunit 62085 "EMADV PD Rule Set AT CalDay" implements "EMADV IPerDiemRuleSetProvider"
{
    internal procedure CalcPerDiemRate(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail"): Boolean
    var
        CustPerDiemRate: Record "EMADV Cust PerDiem Rate";
        PerDiemCalcMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
    begin
    end;
}
