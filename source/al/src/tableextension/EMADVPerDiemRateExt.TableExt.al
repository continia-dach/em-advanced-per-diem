tableextension 62082 "EMADV Per Diem Rate Ext" extends "CEM Per Diem Rate v.2"
{
    fields
    {
        field(62080; "Day trip from 6h"; Decimal)
        {
            Caption = 'One-day trip from 6h';
            DataClassification = CustomerContent;
        }
        field(62081; "Day trip from 11h"; Decimal)
        {
            Caption = 'One-day trip from 11h';
            DataClassification = CustomerContent;
        }
        field(62084; "O/N trip full day"; Decimal)
        {
            Caption = 'Overnight stay - full day';
            DataClassification = CustomerContent;
        }
        field(62085; "O/N trip dep. pre 12pm"; Decimal)
        {
            Caption = 'Overnight stay - left before 12pm';
            DataClassification = CustomerContent;
        }
        field(62086; "O/N trip dep. after 12pm"; Decimal)
        {
            Caption = 'Overnight stay - left after 12pm';
            DataClassification = CustomerContent;
        }
        field(62087; "O/N trip arr. before 5pm"; Decimal)
        {
            Caption = 'Overnight stay - arrived before 5pm';
            DataClassification = CustomerContent;
        }
        field(62088; "O/N trip arr. after 5pm"; Decimal)
        {
            Caption = 'Overnight stay - arrived after 5pm';
            DataClassification = CustomerContent;
        }

        field(62090; "Day trip from 6h taxable"; Decimal)
        {
            Caption = 'One-day trip from 6h  - taxable';
            DataClassification = CustomerContent;
        }
        field(62091; "Day trip from 11h taxable"; Decimal)
        {
            Caption = 'One-day trip from 11h - taxable';
            DataClassification = CustomerContent;
        }
        field(62094; "O/N trip full day taxable"; Decimal)
        {
            Caption = 'Overnight stay - full day - taxable';
            DataClassification = CustomerContent;
        }
        field(62095; "O/N trip dep. pre 12pm taxable"; Decimal)
        {
            Caption = 'Overnight stay - before 12pm - taxable';
            DataClassification = CustomerContent;
        }
        field(62096; "O/N trip dep. after 12pm tax."; Decimal)
        {
            Caption = 'Overnight stay - left after 12pm  - taxable';
            DataClassification = CustomerContent;
        }
        field(62097; "O/N trip arr. before 5pm tax."; Decimal)
        {
            Caption = 'Overnight stay - arrived before 5pm  - taxable';
            DataClassification = CustomerContent;
        }
        field(62098; "O/N trip arr. after 5pm tax."; Decimal)
        {
            Caption = 'Overnight stay - arrived after 5pm - taxable';
            DataClassification = CustomerContent;
        }
    }
}
