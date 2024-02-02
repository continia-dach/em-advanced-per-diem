codeunit 62082 "EMADV PD Rule Set Default" implements "EMADV IPerDiemRuleSetProvider"
{
    internal procedure CalcPerDiemRate(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail")
    begin
        exit;  // We just exit as calculation should be done by default
    end;

    internal procedure UpdatePerDiemDetail(PerDiem: Record "CEM Per Diem"; PerDiemDetail: Record "CEM Per Diem Detail"): Boolean
    begin
    end;
}
