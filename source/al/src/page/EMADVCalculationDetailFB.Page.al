page 62086 "EMADV Calculation Detail FB"
{
    ApplicationArea = All;
    Caption = 'EMADV Calculation Detail FB';
    PageType = CardPart;
    SourceTable = "CEM Per Diem Detail";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(Breakfast; Rec.Breakfast)
                {
                }
                field(Lunch; Rec.Lunch)
                {
                }
                field(Dinner; Rec.Dinner)
                {
                }
                field("Meal Allowance Amount"; Rec."Meal Allowance Amount")
                {
                }
                field("Accommodation Allowance Amount"; Rec."Accommodation Allowance Amount")
                {
                }
                field("Accommodation Allowance"; Rec."Accommodation Allowance")
                {
                }
                field("No. of Destinations"; Rec."No. of Destinations")
                {
                }
            }
        }
    }
}
