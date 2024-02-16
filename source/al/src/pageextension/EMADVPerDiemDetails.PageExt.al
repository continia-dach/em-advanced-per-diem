pageextension 62081 "EMADV Per Diem Details" extends "CEM Per Diem Details"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part("Per Diem Dest. Details"; "EMADV Per Diem Det. Dest FB")
            {
                ApplicationArea = All;
                Visible = MultiDestinationsEnabled;
                Caption = 'Per Diem Destinations';
                SubPageLink = "Per Diem Entry No." = field("Per Diem Entry No."),
                              "Per Diem Detail Entry No." = field("Entry No.");
            }
        }
        modify(Breakfast)
        {
            trigger OnAfterValidate()
            begin
                UpdateDetails();
            end;
        }

        modify(Lunch)
        {
            trigger OnAfterValidate()
            begin
                UpdateDetails();
            end;
        }
        modify(Dinner)
        {
            trigger OnAfterValidate()
            begin
                UpdateDetails();
            end;
        }
        modify("Accommodation Allowance")
        {
            trigger OnAfterValidate()
            begin
                UpdateDetails();
            end;
        }
    }
    // actions
    // {

    //     addfirst(Processing)
    //     {
    //         group(Setup)
    //         {
    //             Caption = 'EM ADV';
    //             action(Update)
    //             {
    //                 ApplicationArea = All;
    //                 Caption = 'Update details';
    //                 Image = Refresh;
    //                 Promoted = true;
    //                 PromotedCategory = Process;
    //                 ToolTip = 'Update current line';

    //                 trigger OnAction()
    //                 begin
    //                     UpdateDetails();
    //                 end;
    //             }
    //         }
    //     }
    // }

    local procedure UpdateDetails()
    var
        CustPerDiemCalMgt: Codeunit "EMADV Cust. Per Diem Calc.Mgt.";
        PerDiemRuleSetProvider: Interface "EMADV IPerDiemRuleSetProvider";

    begin
        CustPerDiemCalMgt.UpdatePerDiemDetail(Rec);
        CurrPage.Update(false);
    end;

    trigger OnOpenPage()
    var
        EMSetup: Record "CEM Expense Management Setup";
    begin
        if not EMSetup.Get() then
            exit;

        MultiDestinationsEnabled := EMSetup."Enable Per Diem Destinations";
    end;

    var
        MultiDestinationsEnabled: Boolean;
}