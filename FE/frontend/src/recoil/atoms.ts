import { atom, RecoilState } from 'recoil';

interface Props {
  [key: string]: boolean | null | string;
}
const isSelectedAtom = atom<Props>({
  key: 'isSelected',
  default: {
    '열린 이슈': false,
    '내가 작성한 이슈': false,
    '나에게 할당된 이슈': false,
    '내가 댓글을 남긴 이슈': false,
    '닫힌 이슈': false,
  },
});

const filterAtom = atom<Props>({
  key: 'filter',
  default: {
    isOpen: 'true',
    specialFilter: '',
    assignee: '',
    label: '',
    milstone: '',
    writer: '',
  },
});

export { isSelectedAtom, filterAtom };
