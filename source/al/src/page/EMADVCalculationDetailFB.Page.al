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
            group(Meal)
            {
                Caption = 'Meal';

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
                field("No. of Destinations"; Rec."No. of Destinations")
                {
                    Visible = false;
                }

            }
            group(Accommodation)
            {
                Caption = 'Accommodation';

                field("Accommodation Allowance"; Rec."Accommodation Allowance")
                {
                }
                field("Accommodation Allowance Amount"; Rec."Accommodation Allowance Amount")
                {
                }
            }
        }
    }
}
