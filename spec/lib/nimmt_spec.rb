require 'spec_helper'

module Nimmt
  describe Controller do
    context 'コンピュータだけでゲームを始めたとき' do
      let(:controller) { Controller.new(players_number: 0, computers_number: 4) }
      subject { controller }

      describe '#start' do
        it 'ゲームを終えることができること' do
          expect { controller.start }.not_to raise_error
        end
      end
    end
  end

  describe Row do
    describe '.all' do
      let(:rows) { Row.all }
      subject { rows }

      it '4つの列が作られること' do
        idxs = rows.map(&:idx)
        expect(idxs).to eq (1..4).to_a
      end
    end

    context '.new with "1"' do
      let(:row) { Row.new(idx: 1) }
      subject { row }

      it { expect(row.cards).to eq [] }
      it { expect(row.idx).to eq 1 }

      describe '#place_card' do
        context 'with a card that have number 10' do
          let(:card) { Card.new(10) }

          it '列に置かれているカードが1つ増えること' do
            expect { row.place_card(card) }.to change { row.cards.size }.by(1)
          end
        end
      end

      context '10のカードが置かれているとき' do
        let(:card) { Card.new(10) }
        before { row.place_card(card) }

        describe '#has_card?' do
          context 'with a card that number 10' do
            it 'should be return true' do
              other_card = Card.new(10)
              expect(row.has_card?(other_card)).to be_truthy
            end
          end

          context 'with a card that number 1' do
            it 'should be return false' do
              other_card = Card.new(1)
              expect(row.has_card?(other_card)).to be_falsy
            end
          end
        end

        describe '#clear' do
          it '列に置かれているカードが0になること' do
            expect { row.clear }.to change { row.cards.size }.to(0)
          end
        end
      end
    end
  end

  describe Card do
    describe '.all' do
      let(:cards) { Card.all }
      subject { cards }

      it '1から104までのカードが作られること' do
        numbers = cards.map(&:number)
        expect(numbers).to eq (1..104).to_a
      end
    end

    context '.new with "2"' do
      let(:card) { Card.new(2) }
      subject { card }

      it { expect(card.number).to eq 2 }
      it { expect(card.cow).to eq 1 }
      it { expect(card.owner).to be_nil }

      describe '#<=>' do
        context 'with a card that have number 1' do
          it { expect(card <=> Card.new(1)).to eq 1 }
        end

        context 'with a card that have number 3' do
          it { expect(card <=> Card.new(3)).to eq -1 }
        end
      end
    end
  end
end
