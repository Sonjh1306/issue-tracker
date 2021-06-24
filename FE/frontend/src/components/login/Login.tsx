import React from 'react';
import styled from 'styled-components';
import Typos from '../../styles/atoms/Typos';
import Buttons from '../../styles/atoms/Buttons';
import { ReactComponent as Logo } from '../../icons/logoLarge.svg';

const Login = () => {
  const url = `https://github.com/login/oauth/authorize?client_id=8f053229e25de08ed09d&scope=user:email&redirect_uri=http://localhost:3000/login/github`;
  const googleUrl = `https://accounts.google.com/o/oauth2/v2/auth?client_id=195028719127-a5r87r9182sidvd6vjs9akod785k5t94.apps.googleusercontent.com&redirect_uri=http://localhost:3000/login/google&response_type=code&scope=https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile&flowName=GeneralOAuthFlow`;

  return (
    <LoginContainer>
      <Logo />
      <a href={url}>
        <GitHubLogin large>GitHub 계정으로 로그인</GitHubLogin>
      </a>
      <a href={googleUrl}>
        <GoogleLogin large>Google 계정으로 로그인</GoogleLogin>
      </a>
      <TextInBetween sm>or</TextInBetween>
      <ManualLogin large>아이디</ManualLogin>
      <ManualLogin large>비밀번호</ManualLogin>
      <Buttons disabled large>
        아이디로 로그인
      </Buttons>
      <Typos link xs>
        회원가입
      </Typos>
    </LoginContainer>
  );
};

const LoginContainer = styled.div`
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  ${props => props.theme.alignCenter}
  flex-direction: column;
  & > * {
    margin-bottom: 20px;
  }
`;

const GitHubLogin = styled(Buttons)`
  margin-top: 50px;
  background-color: ${props => props.theme.greyscale.titleActive};
`;

const GoogleLogin = styled(Buttons)`
  background-color: #4285f4;
`;

const TextInBetween = styled(Typos)`
  color: ${props => props.theme.greyscale.placeholer};
`;

const ManualLogin = styled(Buttons)`
  justify-content: flex-start;
  background-color: ${props => props.theme.greyscale.inputBackgound};
  color: ${props => props.theme.greyscale.placeholer};
`;

export default Login;
