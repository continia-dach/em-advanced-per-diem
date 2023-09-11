codeunit 62081 "EMADV Cust. Per Diem Calc.Mgt."
{


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CEM Per Diem Calc. Engine", OnBeforeFindRateAndUpdateAmtOnDetail, '', false, false)]
    local procedure PerDiemCalcEngine_OnBeforeFindRateAndUpdateAmtOnDetail(var PerDiemDetails: Record "CEM Per Diem Detail"; var IsHandled: Boolean)
    begin
        IsHandled := CalcCustPerDiemRate(PerDiemDetails);
    end;

    internal procedure CalcCustPerDiemRate(var PerDiemDetail: Record "CEM Per Diem Detail") CalculationResult: Boolean
    var
        EMSetup: Record "CEM Expense Management Setup";
        PerDiem: Record "CEM Per Diem";
        PerDiemGroup: Record "CEM Per Diem Group";
        CustPerDiemRate: Record "EMADV Cust PerDiem Rate";
        PerDiemRuleSetProvider: Interface "EMADV IPerDiemRuleSetProvider";
    begin
        if not EMSetup.Get() then
            exit;
        if not EMSetup."Use Custom Per Diem Engine" then
            exit;

        if PerDiemDetail."Per Diem Entry No." = 0 then
            exit
        else
            PerDiem.Get(PerDiemDetail."Per Diem Entry No.");

        if not PerDiemGroup.Get(PerDiem."Per Diem Group Code") then
            exit;

        PerDiemRuleSetProvider := PerDiemGroup."Calculation rule set";
        CalculationResult := PerDiemRuleSetProvider.CalcPerDiemRate(PerDiem, PerDiemDetail);
    end;

    internal procedure GetValidCustPerDiemRate(var CustPerDiemRate: Record "EMADV Cust PerDiem Rate"; var PerDiemDetail: Record "CEM Per Diem Detail"; PerDiem: Record "CEM Per Diem"; CalcMethod: Enum "EMADV Per Diem Calc. Method"): Boolean
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
