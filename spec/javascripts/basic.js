describe("basic test", function() {
  beforeEach(function() {
    App.initialize({current_user: {}});
  });
  afterEach(function() {
    delete App.currentUser;
    delete App.listener;
    Backbone.history.stop();
  });

  it("contains spec with an expectation", function() {
    expect(true).toBe(true);
  });

  it("App is defined", function() {
    expect(App).toBeDefined();
  });

  it("App.Views is defined", function() {
    expect(App.Views).toBeDefined();
  });

  it("App.Modles is defined", function() {
    expect(App.Models).toBeDefined();
  });

  it("App.Collections is defined", function() {
    expect(App.Collections).toBeDefined();
  });

  it("App.Routers is defined", function() {
    expect(App.Routers).toBeDefined();
  });

  it("App.listener is defined", function() {
    expect(App.listener).toBeDefined();
  });

});