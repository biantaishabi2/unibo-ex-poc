defmodule UniboV4.Barcode.Barcode do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Barcode.Barcode.BarcodeNomenclature
    resource UniboV4.Barcode.Barcode.BarcodeNomenclatureTranslation
    resource UniboV4.Barcode.Barcode.BarcodeRule
    resource UniboV4.Barcode.Barcode.BarcodeRuleTranslation
    resource UniboV4.Barcode.Barcode.BarcodeMapping
    resource UniboV4.Barcode.Barcode.GS1ApplicationIdentifier
    resource UniboV4.Barcode.Barcode.Gs1ApplicationIdentifierTranslation
  end
end
