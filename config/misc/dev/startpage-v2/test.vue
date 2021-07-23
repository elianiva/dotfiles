<script>
export default {
  data() {
    return {
      currentCount: 0
    }
  },
  methods: {
    decrement() {
      this.currentCount -= 1
    },
    increment() {
      this.currentCount += 1
    }
  }
}
</script>

<template>
  <div class="counter">
    <h2 class="counter-title">Counter</h2>
    <p class="counter-count">{{ currentCount }}</p>
    <button @click="increment" class="counter-button">Increment</button>
    <button @click="decrement" class="counter-button">Decrement</button>
  </div>
</template>

<style>
.counter {
  border: 10px solid #34495e;
  background-color: #41b883;
  color: white;
  width: 50%;
  margin: 0 auto;
  padding: 2rem;
  margin-bottom: 3rem;
}
.counter-button {
  font-size: 1rem;
  padding: 0.75rem;
  margin: 0 0.5rem;
}
.counter-count {
  font-size: 3rem;
  font-weight: 700;
  margin: 0;
  padding: 1rem;
}
.counter-title {
  font-size: 2rem;
  margin: 0;
}
</style>
