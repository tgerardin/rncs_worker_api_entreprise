require 'rails_helper'

describe DossierEntreprise do
  it { is_expected.to have_db_column(:id).of_type(:uuid) }
  it { is_expected.to have_db_column(:nom_greffe).of_type(:string) }
  it { is_expected.to have_db_column(:type_inscription).of_type(:string) }
  it { is_expected.to have_db_column(:date_immatriculation).of_type(:string) }
  it { is_expected.to have_db_column(:date_premiere_immatriculation).of_type(:string) }
  it { is_expected.to have_db_column(:date_radiation).of_type(:string) }
  it { is_expected.to have_db_column(:date_transfert).of_type(:string) }
  it { is_expected.to have_db_column(:sans_activite).of_type(:string) }
  it { is_expected.to have_db_column(:date_debut_activite).of_type(:string) }
  it { is_expected.to have_db_column(:date_debut_premiere_activite).of_type(:string) }
  it { is_expected.to have_db_column(:date_cessation_activite).of_type(:string) }

  # Associations
  it { is_expected.to have_one(:personne_morale) }
  it { is_expected.to have_one(:personne_physique) }
  it { is_expected.to have_many(:representants) }
  it { is_expected.to have_many(:observations) }
  it { is_expected.to have_many(:etablissements) }

  it_behaves_like 'having event date and label'
  it_behaves_like 'having dossier greffe id'
  it_behaves_like 'having rails timestamps'

  describe 'helper methods' do
    context 'with an entreprise complexe' do
      subject { create :entreprise_complexe }

      its(:etablissement_principal) { is_expected.not_to be_nil }
      its('etablissement_principal.type_etablissement') { is_expected.to eq 'PRI' }
    end

    context 'with an entreprise without siege social' do
      subject { create :entreprise_without_siege_social }

      its(:etablissement_principal) { is_expected.not_to be_nil }
      its('etablissement_principal.type_etablissement') { is_expected.not_to eq 'PRI' } # random
    end
  end
end
