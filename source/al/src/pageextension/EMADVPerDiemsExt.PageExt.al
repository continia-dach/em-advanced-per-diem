pageextension 62083 "EMADV Per Diems Ext." extends "CEM Per Diems"
{
    actions
    {
        addafter(Dimensions)
        {
            action(ShowCalculation)
            {
                ApplicationArea = All;
                Caption = 'Show Calculation';
                RunObject = page "EMADV Per Diem Calc. Card";
                RunPageLink = "Entry No." = field("Entry No.");
                RunPageMode = View;
                Image = ShowList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }
            action(ShowCalculationList)
            {
                ApplicationArea = All;
                Caption = 'Show Calculation';
                RunObject = page "EMADV Per Diem Calc. List2";
                RunPageLink = "Per Diem Entry No." = field("Entry No.");
                RunPageMode = View;
                Image = ShowList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }
        }
    }
}
