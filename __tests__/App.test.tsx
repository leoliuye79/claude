import React from 'react';
import { fireEvent, render } from '@testing-library/react-native';

import App from '../App';

describe('App', () => {
  it('lets the user complete onboarding', () => {
    const screen = render(<App />);

    expect(screen.getByText('你想学哪种语言？')).toBeTruthy();
    fireEvent.press(screen.getByText('进入聊天'));

    expect(screen.getByText('聊天')).toBeTruthy();
    expect(screen.getByText('Mia')).toBeTruthy();
  });

  it('lets the user send a message, view a correction, and save a review card', () => {
    const screen = render(<App />);

    fireEvent.press(screen.getByText('进入聊天'));
    fireEvent.changeText(screen.getByPlaceholderText('用你正在学习的语言发一条消息...'), 'I very like coffee.');
    fireEvent.press(screen.getByText('发送'));

    expect(screen.getByText('这句话可以更自然')).toBeTruthy();
    fireEvent.press(screen.getByText('加入复习'));

    fireEvent.press(screen.getByText('复习'));
    expect(screen.getByText('今天最值得复习的一句')).toBeTruthy();
  });

  it('navigates to tasks and marks a review card as mastered', () => {
    const screen = render(<App />);

    fireEvent.press(screen.getByText('进入聊天'));
    fireEvent.changeText(screen.getByPlaceholderText('用你正在学习的语言发一条消息...'), 'I very like coffee.');
    fireEvent.press(screen.getByText('发送'));
    fireEvent.press(screen.getByText('加入复习'));
    fireEvent.press(screen.getByText('复习'));
    fireEvent.press(screen.getByText('我记住了'));

    fireEvent.press(screen.getByText('任务'));
    expect(screen.getByText('和 Mia 完成 5 轮对话')).toBeTruthy();
  });
});
