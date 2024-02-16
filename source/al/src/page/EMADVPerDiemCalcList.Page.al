page 62089 "EMADV Per Diem Calc. List"
{
    ApplicationArea = All;
    Caption = 'Per Diem calculation details';
    PageType = List;
    SourceTable = "EMADV Per Diem Calculation";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Per Diem Entry No."; Rec."Per Diem Entry No.")
                {
                    ToolTip = 'Specifies the value of the Per Diem Entry No. field.';
                    Visible = false;
                }
                field("Per Diem Det. Entry No."; Rec."Per Diem Det. Entry No.")
                {
                    ToolTip = 'Specifies the value of the Per Diem Detail Entry No. field.';
                    Visible = false;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    Visible = false;
                }
                field("From Time"; Rec."From DateTime")
                {
                    ToolTip = 'Specifies the value of the From Time field.';
                }
                field("To Time"; Rec."To DateTime")
                {
                    ToolTip = 'Specifies the value of the To Time field.';
                }
                field("Destination Country/Region"; Rec."Country/Region")
                {
                    ToolTip = 'Specifies the value of the Destination Country/Region field.';
                    Visible = false;
                }
                field("Destination Name"; Rec."Destination Name")
                {
                    ToolTip = 'Specifies the value of the Destination Name field.';
                }
                field("Domestic Entry"; Rec."Domestic Entry")
                {
                    ToolTip = 'Specifies if the country is marked as domestic country';
                    //TODO consider to hide the field
                }
                field("Duration Integer"; Rec."Day Duration")
                {
                    ToolTip = 'Specifies the value of the Duration field.';
                }

                field("Meal Allowance"; Rec."Daily Meal Allowance")
                {
                    ToolTip = 'Specifies the value of the meal allowance';
                }
                field("Meal Allowance Deductions"; Rec."Meal Allowance Deductions")
                {
                    ToolTip = 'Specifies the amount that will be deducted from the meal allowance';
                    Visible = false;
                    ObsoleteState = Pending;
                }
                field("Meal Reimb. Amount"; Rec."Meal Reimb. Amount")
                {
                    ToolTip = 'Specifies the reimbursed meal amount';
                    Visible = false;
                }
                field("Accommodation Reimb. Amount"; Rec."Accommodation Reimb. Amount")
                {
                    ToolTip = 'Specifies the reimbursed accommodation amount';
                }
                field("Accommodation Allowance"; rec."Daily Accommodation Allowance")
                {
                    ToolTip = 'Specifies the value of the accommodation Allowance.';
                    Visible = false;
                }
                field("AT Per Diem Reimbursed Twelfth"; Rec."AT Per Diem Reimbursed Twelfth")
                {
                    ToolTip = 'Specifies the number of twelth used to calculate the reimbursed amount.';
                    Visible = CalculateAustrianPerDiem;
                }
                field("AT Per Diem Twelfth"; Rec."AT Per Diem Twelfth")
                {
                    ToolTip = 'Specifies the value of the AT Per Diem Twelfth field.';
                    Visible = false;
                }
            }
        }
        area(FactBoxes)
        {
            part(PerDiemInfo; "EMADV Per Diem FB")
            {
                ApplicationArea = all;
                SubPageLink = "Entry No." = field("Per Diem Entry No.");
            }
            part(PerDiemDetailsInfo; "EMADV Calculation Detail FB")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
                SubPageLink = "Per Diem Entry No." = field("Per Diem Entry No."), "Entry No." = field("Per Diem Det. Entry No.");

            }
        }
    }

    actions
    {
        area(Processing)
        {

            action(Update)
            {
                ApplicationArea = All;
                Image = Recalculate;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    UpdatePerDiemCalculation();
                    CurrPage.Update(false);
                end;
            }
            action("Per Diem Details")
            {
                ApplicationArea = All;
                Caption = 'Per Diem Details';
                Ellipsis = true;
                Image = Split;
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'Shift+Ctrl+L';
                ToolTip = 'View or edit per diem details.';
                AboutTitle = 'Per Diem Details';
                AboutText = 'Detailed information about each day of the per diem and each element selected for reimbursement by the expense user.';

                trigger OnAction()
                var
                    PerDiemValidate: Codeunit "CEM Per Diem-Validate";
                begin
                    ShowPerDiemDetails(PerDiem);
                    PerDiemValidate.RUN(PerDiem);
                    CurrPage.UPDATE(FALSE);
                end;
            }
            action(PerDiemGroup)
            {
                ApplicationArea = All;
                Caption = 'Per Diem Group';
                RunObject = Page "CEM Per Diem Group Card";
                //RunPageLink = Code = field "Per Diem Group Code");
                RunPageMode = View;
                Image = Card;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
            }
            action(OpenRateCard)
            {
                ApplicationArea = All;
                Caption = 'Per Diem Rate';
                Image = Line;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    PerDiem: Record "CEM Per Diem";
                    PerDiemRate: Record "CEM Per Diem Rate v.2";
                begin
                    if not PerDiem.Get(Rec."Per Diem Entry No.") then
                        exit;

                    PerDiemRate.SetRange("Per Diem Group Code", PerDiem."Per Diem Group Code");
                    //PerDiemRate.SetRange("Accommodation Allowance Code",
                    PerDiemRate.SetRange("Destination Country/Region", Rec."Country/Region");
                    PerDiemRate.SetFilter("Start Date", '..%1', DT2date(Rec."To DateTime"));
                    if PerDiemRate.FindLast() then
                        Page.RunModal(page::"CEM Per Diem Rate Card v.2", PerDiemRate);
                end;
            }
        }
    }

    trigger OnOpenPage()

    begin
        if not PerDiem.Get(Rec.GetFilter("Per Diem Entry No.")) then
            Error('Cannot find Per Diem Entry with Id: %1', Rec.GetFilter("Per Diem Entry No."));

        SetFields();

        UpdatePerDiemCalculation();
    end;

    local procedure UpdatePerDiemCalculation()
    var
        PerDiemDetail: Record "CEM Per Diem Detail";
        PerDiemGroup: Record "CEM Per Diem Group";
        CustPerDiemCalcMgt: codeunit "EMADV Cust. Per Diem Calc.Mgt.";
    begin
        PerDiemDetail.SetRange("Per Diem Entry No.", PerDiem."Entry No.");
        if PerDiemDetail.FindFirst() then
            CustPerDiemCalcMgt.CalcCustPerDiemRate(PerDiemDetail);
        CurrPage.Update(false);
    end;

    internal procedure ShowPerDiemDetails(PerDiem: Record "CEM Per Diem")
    var
        PerDiemDetail: Record "CEM Per Diem Detail";
        CustPerDiemCalcMgt: codeunit "EMADV Cust. Per Diem Calc.Mgt.";
    begin
        PerDiemDetail.SETRANGE("Per Diem Entry No.", PerDiem."Entry No.");
        PAGE.RUNMODAL(PAGE::"CEM Per Diem Details", PerDiemDetail);
        if PerDiemDetail.FindFirst() then begin
            CustPerDiemCalcMgt.CalcCustPerDiemRate(PerDiemDetail);
            CurrPage.Update(false);
        end;
    end;

    local procedure SetFields()
    var
        PerDiemGroup: Record "CEM Per Diem Group";
    begin
        // Set Austrian rules field visibility
        if PerDiemGroup.Get(PerDiem."Per Diem Group Code") then
            CalculateAustrianPerDiem := (PerDiemGroup."Calculation rule set" in [PerDiemGroup."Calculation rule set"::Austria24h, PerDiemGroup."Calculation rule set"::AustriaByDay]);

    end;

    var
        PerDiem: Record "CEM Per Diem";
        CalculateAustrianPerDiem: Boolean;
}
