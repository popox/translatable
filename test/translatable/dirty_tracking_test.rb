require File.expand_path('../../test_helper', __FILE__)

class DirtyTrackingTest < Test::Unit::TestCase
  test "dirty tracking works" do
    post = Post.create(:title => 'title', :content => 'content')
    assert_equal [], post.changed

    post.title = 'changed title'
    assert_equal ['title'], post.changed

    post.content = 'changed content'
    assert_included 'title', post.changed
    assert_included 'content', post.changed
  end

  test 'dirty tracking works per a locale' do
    post = Post.create(:title => 'title', :content => 'content')
    assert_equal [], post.changed

    post.title = 'changed title'
    assert_equal({ 'title' => ['title', 'changed title'] }, post.changes)
    post.save

    # Automatic fallback on data values
    I18n.locale = :de
    assert_equal 'changed title', post.translate.title

    post.translate.title = 'Titel'
    assert_equal({ 'title' => [nil, 'Titel'] }, post.changes)
  end

  # ummm ... is this actually desired behaviour? probably depends on how we use it
  test 'dirty tracking works after locale switching' do
    post = Post.create(:title => 'title', :content => 'content')
    assert_equal [], post.changed

    post.title = 'changed title'
    I18n.locale = :de
    assert_equal ['title'], post.changed
  end

  test 'dirty tracking works for blank assignment' do
    post = Post.create(:title => 'title', :content => 'content')
    assert_equal [], post.changed

    post.title = ''
    assert_equal({ 'title' => ['title', ''] }, post.changes)
    post.save
  end

  test 'dirty tracking works for nil assignment' do
    post = Post.create(:title => 'title', :content => 'content')
    assert_equal [], post.changed

    post.title = nil
    assert_equal({ 'title' => ['title', nil] }, post.changes)
    post.save
  end

  test 'dirty tracking does not track fields with identical values' do
    post = Post.create(:title => 'title', :content => 'content')
    assert_equal [], post.changed
    
    post.title = 'title'
    assert_equal [], post.changed
    
    post.title = 'changed title'
    assert_equal({ 'title' => ['title', 'changed title'] }, post.changes)
    
    post.title = 'doubly changed title'
    assert_equal({ 'title' => ['title', 'doubly changed title'] }, post.changes)
    
    post.title = 'title'
    assert_equal [], post.changed
  end

end
