codeunit 62084 "EMADV PD Rule Set AT 24h" implements "EMADV IPerDiemRuleSetProvider"
{
    internal procedure CalcPerDiemRate(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail")
    var
        CustPerDiemRate: Record "EMADV Cust PerDiem Rate";
        PerDiemCalcMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
    begin
    end;
}
