interface "EMADV IPerDiemRuleSetProvider"
{
    procedure CalcPerDiemRate(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail"): Boolean;
    procedure UpdatePerDiemDetail(PerDiem: Record "CEM Per Diem"; PerDiemDetail: Record "CEM Per Diem Detail"): Boolean;
    //procedure GetTripDuration(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail");

    //procedure GetTripDurationInTwelth(PerDiem: Record "CEM Per Diem"): text;
}
