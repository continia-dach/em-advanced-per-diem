codeunit 62083 "EMADV PD Rule Set DE" implements "EMADV IPerDiemRuleSetProvider"
{
    internal procedure CalcPerDiemRate(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail"): Boolean
    var
        CustPerDiemRate: Record "EMADV Cust PerDiem Rate";
        PerDiemCalcMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
    begin
        // TODO Create setup option "Use cust. per diem rate engine"
        if DT2DATE(PerDiem."Departure Date/Time") = PerDiemDetail.Date then begin
            //First Day
            if not PerDiemCalcMgt.GetValidCustPerDiemRate(CustPerDiemRate, PerDiemDetail, PerDiem, CustPerDiemRate."Calculation Method"::FirstDay) then
                exit;

            if CustPerDiemRate.GetDeductionAmount(PerDiemDetail) then
                exit(PerDiemDetail.Modify);
        end else begin
            if (DT2DATE(PerDiem."Return Date/Time") = PerDiemDetail.Date) and
               (DT2DATE(PerDiem."Departure Date/Time") <> PerDiemDetail.Date) then begin
                // Last Day
                if not PerDiemCalcMgt.GetValidCustPerDiemRate(CustPerDiemRate, PerDiemDetail, PerDiem, CustPerDiemRate."Calculation Method"::LastDay) then
                    exit;

                if CustPerDiemRate.GetDeductionAmount(PerDiemDetail) then
                    exit(PerDiemDetail.Modify);
            end else begin
                // Full Day
                if not PerDiemCalcMgt.GetValidCustPerDiemRate(CustPerDiemRate, PerDiemDetail, PerDiem, CustPerDiemRate."Calculation Method"::FullDay) then
                    exit;

                if CustPerDiemRate.GetDeductionAmount(PerDiemDetail) then
                    exit(PerDiemDetail.Modify);
            end;

        end;

    end;
}
