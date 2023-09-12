codeunit 62084 "EMADV PD Rule Set AT 24h" implements "EMADV IPerDiemRuleSetProvider"
{
    internal procedure CalcPerDiemRate(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail")
    var
        CustPerDiemRate: Record "EMADV Cust PerDiem Rate";
        PerDiemCalcMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
        EMSetup: Record "CEM Expense Management Setup";
    begin
        if not EMSetup.Get() then
            exit;

        if EMSetup."Enable Per Diem Destinations" then
            Message('TODO')
        else
            CalculateSingleDestination(PerDiem, PerDiemDetail);
    end;

    local procedure CalculateSingleDestination(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail")
    var
        FirstDay: Boolean;
        LastDay: Boolean;
        DayDuration: Duration;
    begin
        FirstDay := PerDiemDetail.Date = DT2Date(PerDiem."Departure Date/Time");
        LastDay := PerDiemDetail.Date = DT2Date(PerDiem."Return Date/Time");

        case true of
            // 1st day AND last day = One day trip
            (FirstDay and LastDay):
                begin
                    DayDuration := PerDiem."Return Date/Time" - PerDiem."Departure Date/Time";
                end;
            // 1st day and NOT last day
            (FirstDay and (not LastDay)):
                begin
                    DayDuration := CreateDateTime(PerDiemDetail.Date + 1, 000000T) - PerDiem."Departure Date/Time";
                end;

            // Last day
            ((not FirstDay) and LastDay):
                begin
                    DayDuration := PerDiem."Return Date/Time" - CreateDateTime(PerDiemDetail.Date, 000000T);
                end;
            //in-between day    
            else begin
                DayDuration := CreateDateTime(PerDiemDetail.Date + 1, 000000T) - CreateDateTime(PerDiemDetail.Date, 000000T);
            end;

        end;
    end;
}
