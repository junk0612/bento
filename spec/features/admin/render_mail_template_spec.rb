require 'rails_helper'

RSpec.feature 'お弁当やさんへのメールの文言を表示する', type: :feature do
  given!(:order) { create(:order) }
  given!(:jouben_dai) { create(:lunchbox, name: '上弁ライス大') }
  given!(:tokuben_futsuu) { create(:lunchbox, name: '特弁ライス普') }

  background do
    Timecop.freeze(order.date) do
      create_list(:order_item, 2, lunchbox: jouben_dai, order: order)
      create_list(:order_item, 3, lunchbox: tokuben_futsuu, order: order)
    end
  end

  context 'その日の予約を締め切る前' do
    it 'メールの文言は表示されていない' do
      Timecop.freeze(order.date) do
        visit todays_order_admin_orders_path

        text = '本日のお弁当の注文をお願いします。内容は以下のとおりです。- 上弁ライス大: 2 個- 特弁ライス普: 3 個よろしくお願いいたします。'

        expect(page).not_to have_text text
      end
    end
  end

  context 'その日の予約を締め切った後' do
    it '予約された弁当とその個数が整形されて表示される' do
      Timecop.freeze(order.date) do
        visit todays_order_admin_orders_path
        click_button('予約を締め切る')

        text = '本日のお弁当の注文をお願いします。内容は以下のとおりです。- 上弁ライス大: 2 個- 特弁ライス普: 3 個よろしくお願いいたします。'

        within '.mail-template' do
          expect(page).to have_text text
        end
      end
    end
  end
end
