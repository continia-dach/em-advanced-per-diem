interface "EMADV IPerDiemRuleSetProvider"
{
    procedure CalcPerDiemRate(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail");
    //procedure GetTripDuration(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail");

    //procedure GetTripDurationInTwelth(PerDiem: Record "CEM Per Diem"): text;
}
