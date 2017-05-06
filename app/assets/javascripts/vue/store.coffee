import { Vue } from 'vue/instance'
import Vuex from 'vuex'

Vue.use Vuex

store = new Vuex.Store
  state:
    collection: {}

  actions:
    add_link: (context, data) -> context.commit 'ADD_LINK', data
    remove_link: (context, data) -> context.commit 'REMOVE_LINK', data
    move_link: (context, data) -> context.commit 'MOVE_LINK', data
    rename_group: (context, data) -> context.commit 'RENAME_GROUP', data

  mutations:
    ADD_LINK: (state, data) ->
      last_in_group = state.collection.links
        .filter (v) -> v.group == data.group
        .last()
      index = state.collection.links.indexOf(last_in_group)
      state.collection.links.splice(index + 1, 0, data)

    REMOVE_LINK: (state, data) ->
      state.collection.links.splice(
        state.collection.links.indexOf(data),
        1
      )

    MOVE_LINK: (state, {from_index, to_index, group_index}) ->
      group = state.collection.links[group_index].group
      from_element = state.collection.links.splice(from_index, 1)[0]

      from_element.group = group unless from_element.group == group
      state.collection.links.splice(to_index, 0, from_element)

    RENAME_GROUP: (state, {from_name, to_name}) ->
      state.collection.links.forEach (link) ->
        link.group = to_name if link.group == from_name

  getters:
    autocomplete_url: -> store.autocomplete_url
    collection: (store) -> store.collection
    links: (store) -> store.collection.links
    groups: (store) -> store.collection.links.map((v) -> v.group).unique()
    grouped_links: (store) -> store.collection.links.groupBy((v) -> v.group)

  modules: {}

window.store = store unless process.env.NODE_ENV == 'production'
export { store }