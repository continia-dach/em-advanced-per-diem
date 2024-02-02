codeunit 62083 "EMADV PD Rule Set DE" implements "EMADV IPerDiemRuleSetProvider"
{
    internal procedure CalcPerDiemRate(var PerDiem: Record "CEM Per Diem"; var PerDiemDetail: Record "CEM Per Diem Detail")
    var
        //CustPerDiemRate: Record "EMADV Cust PerDiem Rate";
        PerDiemCalcMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
        RateFound: Boolean;
    begin
        /*   // TODO Create setup option "Use cust. per diem rate engine"
           if DT2DATE(PerDiem."Departure Date/Time") = PerDiemDetail.Date then begin
               //First Day
               RateFound := PerDiemCalcMgt.GetValidCustPerDiemRate(CustPerDiemRate, PerDiemDetail, PerDiem, PerDiem."Departure Country/Region", CustPerDiemRate."Calculation Method"::FirstDay);

           end else begin
               if (DT2DATE(PerDiem."Return Date/Time") = PerDiemDetail.Date) and
                  (DT2DATE(PerDiem."Departure Date/Time") <> PerDiemDetail.Date) then begin
                   // Last Day
                   RateFound := PerDiemCalcMgt.GetValidCustPerDiemRate(CustPerDiemRate, PerDiemDetail, PerDiem, PerDiem."Destination Country/Region", CustPerDiemRate."Calculation Method"::LastDay);
                   CustPerDiemRate.GetDeductionAmount(PerDiemDetail);
               end else begin
                   // Full Day
                   //TODO Include per diem deatils
                   RateFound := PerDiemCalcMgt.GetValidCustPerDiemRate(CustPerDiemRate, PerDiemDetail, PerDiem, 'TODO', CustPerDiemRate."Calculation Method"::FullDay);
               end;
           end;
           if RateFound then begin
               CustPerDiemRate.GetDeductionAmount(PerDiemDetail);
               if PerDiemDetail."Accommodation Allowance" then
                   PerDiemDetail."Accommodation Allowance Amount" := CustPerDiemRate."Daily Accommodation Allowance";
           end
           */
    end;

    internal procedure UpdatePerDiemDetail(PerDiem: Record "CEM Per Diem"; PerDiemDetail: Record "CEM Per Diem Detail"): Boolean
    begin
    end;
}
