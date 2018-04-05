ActiveAdmin.register BlackList do

  config.batch_actions = false

  index as: :blog do

    title do |bl|
      span bl.url, class: 'c-button c-button--ghost'
    end

    body do |bl|
      div class: 'meta' do
        p bl.log.split("\n").join("<br />").html_safe
      end

    end
  end

end
