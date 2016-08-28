module AuthSupport

  def new_question(question)
    visit new_thr_path
    fill_in :thr_title, with: question.title
    fill_in :thr_content, with: question.content
    fill_in 'thr[tagnames]', with: question.tagnames
    fill_in 'thr[captcha]', with: SimpleCaptcha::SimpleCaptchaData.first.value
    click_button I18n.t(:send)
  end

end
