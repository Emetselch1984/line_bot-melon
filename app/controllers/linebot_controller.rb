class LinebotController < ApplicationController
  require 'line/bot'
  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]
  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          seed1 = select_word
          seed2 = select_word
          while seed1 == seed2
            seed2 = select_word
          end
          message = [{
                         type: 'text',
                         text: "今日の晩御飯は,"
                     },{
                         type: 'text',
                         text: "#{seed1} !!"
                     }]
          client.reply_message(event['replyToken'], message)
        end
      end
    }
    head :ok
  end
  private
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_id = ENV["LINE_CHANNEL_ID"]
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
  def select_word
    # この中を変えると返ってくるキーワードが変わる
    seeds = ["ブルターニュ産 オマール海老のコンソメゼリー寄せ キャヴィアと滑らかなカリフラワーのムースリーヌ",
             "自家燻製したノルウェーサーモンと帆立貝柱のムースのキャベツ包み蒸し 生雲丹とパセリのヴルーテ",
             "手長海老のポワレとサフランリゾット 濃厚な甲殻類のクリームソース",
             "国産牛フィレ肉のポワレ 季節の温野菜とマスタードソース オレンジの香りを纏ったブールパチュー",
             "木の実とキャラメルのタルトフィーヌ 濃厚なミルクのソルベ シナモンの風味",
             "ちくわ",
             "けんたろう",
             "お前に食わせる飯はねぇ",
             "自家製サーモンのマリネ 海の恵みの宝石仕立て新鮮な千葉産ガーデングリーンとキャビアを添えて",
             "フランス産トリュフと白舞茸の蒸しコンソメスープロワイヤル仕立て",
             "鱸のポアレ 高知県産完熟トマト蜂蜜風味のシャンパンクリームソース海草と群馬県産濃緑ほうれん草のソテーを添えて",
             "特選国産牛フィレ肉とフォアグラのロースト ランド風ポテトと野生茸のフリカッセ 旬の彩り野菜 フランス産モリーユ茸とヴィンテージポルト酒のソース",
             "ウェディングケーキ 苺のティラミスとバルサミコマリネ ストロベリーアイスクリーム"]
    seeds.sample
  end
end