describe Fastlane::Actions::MatchEnvfileAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with(tst)

      Fastlane::Actions::MatchEnvfileAction.run(nil)
    end
  end
end
