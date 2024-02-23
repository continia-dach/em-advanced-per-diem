page 62086 "EMADV Calculation Detail FB"
{
    ApplicationArea = All;
    Caption = 'Day Details';
    PageType = CardPart;
    SourceTable = "CEM Per Diem Detail";

    layout
    {
        area(content)
        {
            group(PerDiemDate)
            {

                ShowCaption = false;
                field(Date; Rec.Date)
                {
                }
            }
            group(Meal)
            {
                Caption = 'Meal';

                field(Breakfast; Rec.Breakfast)
                {
                    ToolTip = 'Shows if breakfast has been selected for this day.';
                }
                field(Lunch; Rec.Lunch)
                {
                    ToolTip = 'Shows if lunch has been selected for this day.';
                }
                field(Dinner; Rec.Dinner)
                {
                    ToolTip = 'Shows if dinner has been selected for this day.';
                }
                field("Meal Allowance Amount"; Rec."Meal Allowance Amount")
                {
                    ToolTip = 'Specifies the meal allowance amount of the day.';
                }
                field("No. of Destinations"; Rec."No. of Destinations")
                {
                    ToolTip = 'Specifies the number of destination of this day.';
                    Visible = false;
                }
            }
            group(Accommodation)
            {
                Caption = 'Accommodation';

                field("Accommodation Allowance"; Rec."Accommodation Allowance")
                {
                    ToolTip = 'Specifies if accommodation has been selected for this day.';
                }
                field("Accommodation Allowance Amount"; Rec."Accommodation Allowance Amount")
                {
                    ToolTip = 'Specifies the accommodation allowance amount of this day.';
                }
            }
        }
    }
}