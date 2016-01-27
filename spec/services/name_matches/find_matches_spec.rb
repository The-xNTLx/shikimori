describe NameMatches::FindMatches do
  let(:service) { NameMatches::FindMatches.new names, Anime.name, options }
  let(:refresher) { NameMatches::Refresh.new }

  describe '#call' do
    let!(:anime_1) { create :anime, :tv, name: 'Hunter x Hunter (2000)' }

    let(:names) { ['Hunter x Hunter'] }
    let(:options) {{ }}

    subject do
      refresher.perform Anime.name
      service.call
    end

    describe 'no priority' do
      context 'single match' do
        it { is_expected.to eq [anime_1] }
      end

      context 'multiple matches' do
        let!(:anime_2) { create :anime, :tv, name: 'Hunter x Hunter tv' }
        it { is_expected.to eq [anime_1, anime_2] }
      end
    end

    describe 'order by priority' do
      let!(:anime_2) { create :anime, :ova, name: 'Hunter x Hunter' }
      it { is_expected.to eq [anime_1] }
    end

    describe 'order by group' do
      let!(:anime_2) { create :anime, :tv, name: 'Hunter x Hunter' }
      it { is_expected.to eq [anime_2] }
    end

    describe 'order by priority + group' do
      let!(:anime_2) { create :anime, :tv, name: 'Hunter x Hunter' }
      let!(:anime_3) { create :anime, :ova, name: 'Hunter x Hunter' }
      it { is_expected.to eq [anime_2] }
    end

    describe 'ambiguousity resolve' do
      pending
    end
  end
end
