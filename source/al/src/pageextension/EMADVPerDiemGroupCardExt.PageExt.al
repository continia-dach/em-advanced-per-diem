pageextension 62082 "EMADV Per Diem Group Card Ext." extends "CEM Per Diem Group Card"
{
    layout
    {
        addafter(Default)
        {
            field("Calculation rule set"; Rec."Calculation rule set")
            {
                ApplicationArea = All;
            }
        }
    }
}
