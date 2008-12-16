require File.dirname(__FILE__) + '/../../test_helper'

##
# Here we test polimorphic relationships using the relate & unrelate 
# actions.
#
class Admin::AssetsControllerTest < ActionController::TestCase

  def setup
    typus_user = typus_users(:admin)
    @request.session[:typus] = typus_user.id
  end

  def test_should_test_polymorphic_relationship_message
    post_ = posts(:published)
    get :new, { :back_to => "/admin/posts/#{post_.id}/edit", :resource => post_.class.name, :resource_id => post_.id }
    assert_match "You're adding a new Asset to a Post. Do you want to cancel it?", @response.body
  end

  def test_should_create_a_polymorphic_relationship

    post_ = posts(:published)
    assert_equal 2, post_.assets.size

    post :create, { :back_to => "/admin/posts/#{post_.id}/edit", :resource => post_.class.name, :resource_id => post_.id }
    assert_response :redirect
    assert_redirected_to '/admin/posts/1/edit'

    assert_equal 3, post_.assets.size
    assert flash[:success]
    assert_equal "Asset successfully assigned to Post.", flash[:success]

  end

  def test_should_unrelate_a_polymorphic_relationship

    post_ = posts(:published)
    assert_equal 2, post_.assets.size

    @request.env["HTTP_REFERER"] = "/admin/posts/#{post_.id}/edit"

    get :unrelate, { :id => post_.assets.first.id, :model => post_.class.name, :model_id => post_.id }
    assert_response :redirect
    assert_redirected_to @request.env["HTTP_REFERER"]
    assert flash[:success]
    assert_match "Asset removed from Post.", flash[:success]

    assert_equal 1, post_.assets.size

  end

end