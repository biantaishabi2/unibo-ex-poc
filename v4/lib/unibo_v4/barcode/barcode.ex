defmodule UniboV4.Barcode do
  use Ash.Domain

  resources do
    resource UniboV4.Barcode.BarcodeNomenclature
    resource UniboV4.Barcode.BarcodeNomenclatureTranslation
    resource UniboV4.Barcode.BarcodeRule
    resource UniboV4.Barcode.BarcodeRuleTranslation
    resource UniboV4.Barcode.BarcodeMapping
    resource UniboV4.Barcode.GS1ApplicationIdentifier
    resource UniboV4.Barcode.GS1ApplicationIdentifierTranslation
  end
end
