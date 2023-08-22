codeunit 62081 "EMADV Cust. Per Diem Calc.Mgt."
{


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CEM Per Diem Calc. Engine", OnBeforeFindRateAndUpdateAmtOnDetail, '', false, false)]
    local procedure PerDiemCalcEngine_OnBeforeFindRateAndUpdateAmtOnDetail(var PerDiemDetails: Record "CEM Per Diem Detail"; var IsHandled: Boolean)
    begin
        IsHandled := CalcCustPerDiemRate(PerDiemDetails);
    end;

    internal procedure CalcCustPerDiemRate(var PerDiemDetail: Record "CEM Per Diem Detail"): Boolean
    var
        EMSetup: Record "CEM Expense Management Setup";
        PerDiem: Record "CEM Per Diem";
        CustPerDiemRate: Record "EMADV Cust PerDiem Rate";
    begin
        if not EMSetup.Get() then
            exit;
        if not EMSetup."Use Custom Per Diem Engine" then
            exit;

        if PerDiemDetail."Per Diem Entry No." = 0 then
            exit
        else
            PerDiem.Get(PerDiemDetail."Per Diem Entry No.");

        // TODO Create setup option "Use cust. per diem rate engine"
        if DT2DATE(PerDiem."Departure Date/Time") = PerDiemDetail.Date then begin
            //First Day
            if not GetValidCustPerDiemRate(CustPerDiemRate, PerDiemDetail, PerDiem, CustPerDiemRate."Calculation Method"::FirstDay) then
                exit;

            if CustPerDiemRate.GetDeductionAmount(PerDiemDetail) then
                exit(PerDiemDetail.Modify);
        end else begin
            if (DT2DATE(PerDiem."Return Date/Time") = PerDiemDetail.Date) and
               (DT2DATE(PerDiem."Departure Date/Time") <> PerDiemDetail.Date) then begin
                // Last Day
                if not GetValidCustPerDiemRate(CustPerDiemRate, PerDiemDetail, PerDiem, CustPerDiemRate."Calculation Method"::LastDay) then
                    exit;

                if CustPerDiemRate.GetDeductionAmount(PerDiemDetail) then
                    exit(PerDiemDetail.Modify);
            end else begin
                // Full DAy
                if not GetValidCustPerDiemRate(CustPerDiemRate, PerDiemDetail, PerDiem, CustPerDiemRate."Calculation Method"::FullDay) then
                    exit;

                if CustPerDiemRate.GetDeductionAmount(PerDiemDetail) then
                    exit(PerDiemDetail.Modify);
            end;

        end;

    end;

    local procedure GetValidCustPerDiemRate(var CustPerDiemRate: Record "EMADV Cust PerDiem Rate"; var PerDiemDetail: Record "CEM Per Diem Detail"; PerDiem: Record "CEM Per Diem"; CalcMethod: Enum "EMADV Per Diem Calc. Method"): Boolean
    var

    begin
        CustPerDiemRate.SetRange("Per Diem Group Code", PerDiem."Per Diem Group Code");
        CustPerDiemRate.SetRange("Destination Country/Region", PerDiem."Destination Country/Region");
        CustPerDiemRate.SetFilter("Start Date", '..%1', PerDiemDetail.Date);
        //CustPerDiemRate.SetRange("Accommodation Allowance Code", PerDiem.);
        CustPerDiemRate.SetRange("Calculation Method", CalcMethod);
        //CustPerDiemRate.SetRange("From Hour", CustPerDiemRate."From Hour");
        exit(CustPerDiemRate.FindLast());
    end;
}
